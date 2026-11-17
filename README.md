# Fitness Club

Проект построен на примере продаж магазина фитнес-товаров. **Все данные синтетические и предназначены исключительно для учебных целей.**

## Цель проекта

Очистить исходную выгрузку в Excel с помощью Power Query и преобразовать её в набор взаимосвязанных таблиц. На основе этих таблиц создать реляционную базу данных в PostgreSQL, а затем рассчитать показатели продаж SQL-запросами.

## База данных

Скрипты создают локальную базу PostgreSQL `fitness_club_db` и семь связанных таблиц в схеме `public`.

| Скрипт | Что делает |
| --- | --- |
| [`00_create_database.sql`](sql/00_create_database.sql) | Создаёт `fitness_club_db` при подключении к служебной базе `postgres`. |
| [`01_shema.sql`](sql/01_shema.sql) | Создаёт таблицы, ключи и ограничения в новой базе. |

### Связи между таблицами

```mermaid
erDiagram
    direction LR
    customers ||..o{ orders : customer_id
    managers |o..o{ orders : manager_id
    sales_channels ||..o{ orders : sales_channel_id
    orders ||--o{ order_items : order_id
    products ||..o{ order_items : product_id
    orders ||..o{ payments : order_id
```

Позиция заказа определяется парой `order_id` и `line_no`. У заказа может быть несколько позиций и платежей. Поле `manager_id` допускает `NULL`.

## Локальный запуск

Для запуска понадобятся работающий сервер PostgreSQL и клиент `psql`. [Установщики PostgreSQL](https://www.postgresql.org/download/)

Откройте терминал в корне репозитория и выполните команды по очереди.

```sh
psql -X -h localhost -U postgres -d postgres -v ON_ERROR_STOP=1 -f sql/00_create_database.sql
psql -X -h localhost -U postgres -d fitness_club_db -v ON_ERROR_STOP=1 -f sql/01_shema.sql
```

Параметр `-U` задаёт имя вашей локальной роли PostgreSQL. Если сервер запросит пароль, введите пароль этой роли. Если терминал не находит `psql`, добавьте каталог `bin` PostgreSQL в `PATH`.

Эта команда покажет семь созданных таблиц схемы `public`.

```sh
psql -X -h localhost -U postgres -d fitness_club_db -c "\dt public.*"
```
