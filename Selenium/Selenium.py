#Написать программу, которая собирает входящие письма из своего или тестового почтового ящика и сложить данные о письмах в базу данных (от кого, дата отправки, тема письма,
# текст письма полный) Логин тестового ящика: study.ai_172@mail.ru Пароль тестового ящика: NextPassword172#

from functools import reduce
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.support.ui import WebDriverWait as WDW
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
from selenium.webdriver.common.action_chains import ActionChains
import time
from pymongo import MongoClient

client = MongoClient('localhost',27017)
db = client['letters_db']
correspondence = db.correspondence

login = "study.ai_172"
pwd = "NextPassword172#"
url = "https://account.mail.ru/login/"

# Запуск и авторизация
chrome_options = Options()
chrome_options.add_argument("start-maximized")

s = Service('./chromedriver.exe')
driver = webdriver.Chrome(service=s, options=chrome_options)
driver.get(url)

login = WDW(driver, 30).until(EC.presence_of_element_located((By.NAME,'username')))
login.send_keys('study.ai_172')
login.submit()
password = WDW(driver, 30).until(EC.visibility_of_element_located((By.NAME,'password')))
password.send_keys('NextPassword172#')
password.submit()

#Подсчитаем количество писем в почтовом ящике
inbox = WDW(driver, 10).until(EC.visibility_of_element_located((By.CLASS_NAME,'nav__item_active')))
title = inbox.get_attribute('title')
m = [int(m) for m in str.split(title) if m.isdigit()]
mails = reduce(lambda x, y: x + y, m)
print(f"Писем в ящике: {mails}")


#Собираем ссылки на письма
links_wait = WDW(driver, 30).until(EC.visibility_of_element_located((By.CLASS_NAME,'js-letter-list-item')))
links_list = driver.find_elements(By.CLASS_NAME,'js-letter-list-item')
links_box = set()

for a in links_list:
    links_box.add(a.get_attribute('href'))

while len(links_box) != mails:
    actions = ActionChains(driver)
    actions.move_to_element(links_list[-1])
    actions.perform()
    time.sleep(1)
    links_list = driver.find_elements(By.CLASS_NAME,'js-letter-list-item')
    for a in links_list:
        links_box.add(a.get_attribute('href'))
    print(f"Итого ссылок: {len(links_box)}")


#Собираем инфо из писем
content = []
for a in links_box:
    driver.get(a)
    letter_author_wrapper = WDW(driver, 100).until(EC.presence_of_element_located((By.CLASS_NAME, 'letter__author')))
    doc = {
        'author': letter_author_wrapper.find_element(By.CLASS_NAME,'letter-contact').get_attribute('title'),
        'date': letter_author_wrapper.find_element(By.CLASS_NAME,'letter__date').text,
        'title': driver.find_element(By.CLASS_NAME,'thread-subject').text,
        'body': driver.find_element(By.CLASS_NAME,'letter-body').text
    }
    content.append(doc)
    correspondence.update_one(doc, {'$set': doc}, upsert=True)
    print(f"Собрано из: {a}")

for doc in correspondence.find({}):
    print(doc)




# driver.close()