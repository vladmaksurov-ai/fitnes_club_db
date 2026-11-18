"""Загрузка результатов SQL-анализа для ноутбука Fitness Club."""

from getpass import getpass
from pathlib import Path

import pandas as pd
import sqlparse
from sqlalchemy import URL, create_engine


def load_analysis_results(
    refresh: bool = False,
) -> tuple[pd.DataFrame, pd.DataFrame, pd.DataFrame]:
    """Вернуть таблицы по месяцам, каналам и товарам в указанном порядке.

    При чтении CSV проверяет обязательные колонки и уникальность ключей.
    При refresh=True или отсутствии файла выполняет три SELECT в PostgreSQL
    и обновляет все CSV.
    """
    project_root = Path(__file__).resolve().parents[1]
    outputs_dir = project_root / "data" / "outputs"
    monthly_csv = outputs_dir / "monthly_payments.csv"
    channels_csv = outputs_dir / "sales_channel.csv"
    products_csv = outputs_dir / "products.csv"
    csv_paths = (monthly_csv, channels_csv, products_csv)

    if not refresh and all(path.is_file() for path in csv_paths):
        results = (
            pd.read_csv(monthly_csv, encoding="utf-8"),
            pd.read_csv(channels_csv, encoding="utf-8"),
            pd.read_csv(products_csv, encoding="utf-8"),
        )
        expected_schemas = (
            ("order_month", {
                "order_month",
                "paid_thousand_rub",
                "refunded_thousand_rub",
                "net_paid_thousand_rub",
            }),
            ("sales_channel_id", {
                "sales_channel_id",
                "sales_channel",
                "total_order_count",
                "refunded_count",
                "refunded_order_pct",
                "net_paid_thousand_rub",
            }),
            ("product_id", {
                "product_id",
                "product_name",
                "sales_rub_thd",
                "gross_profit_rub_thd",
            }),
        )
        for result, csv_path, (key_column, required_columns) in zip(
            results, csv_paths, expected_schemas, strict=True
        ):
            missing_columns = required_columns.difference(result.columns)
            if missing_columns:
                raise ValueError(
                    f"В {csv_path.name} нет обязательных колонок: "
                    f"{', '.join(sorted(missing_columns))}"
                )

            key_values = result[key_column]
            if key_values.isna().any():
                raise ValueError(f"В {csv_path.name} есть пустые значения в {key_column}")
            if not key_values.is_unique:
                raise ValueError(f"В {csv_path.name} повторяются значения {key_column}")

        return results

    sql_path = project_root / "sql" / "04_analysis.sql"
    monthly_sql, channels_sql, products_sql = sqlparse.split(
        sql_path.read_text(encoding="utf-8-sig")
    )
    engine = create_engine(
        URL.create(
            "postgresql+psycopg",
            username="postgres",
            password=getpass("Пароль PostgreSQL: "),
            host="localhost",
            port=5432,
            database="fitness_club_db",
        )
    )
    try:
        with engine.connect() as connection:
            results = (
                pd.read_sql_query(monthly_sql, connection),
                pd.read_sql_query(channels_sql, connection),
                pd.read_sql_query(products_sql, connection),
            )
    finally:
        engine.dispose()

    outputs_dir.mkdir(parents=True, exist_ok=True)
    for result, csv_path in zip(results, csv_paths, strict=True):
        result.to_csv(csv_path, index=False, encoding="utf-8")
    return results
