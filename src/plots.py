"""Графики по результатам SQL-анализа Fitness Club."""

import matplotlib.dates as mdates
import matplotlib.pyplot as plt
import pandas as pd


def plot_monthly_payments(monthly_payments: pd.DataFrame) -> None:
    """Показать динамику оплат за вычетом возвратов по месяцу заказа."""
    _, ax = plt.subplots(figsize=(10, 4), layout="constrained")
    months = pd.to_datetime(monthly_payments["order_month"])
    ax.plot(
        months,
        monthly_payments["net_paid_thousand_rub"],
        color="#166A73",
        marker="o",
        linewidth=2,
    )
    ax.xaxis.set_major_locator(mdates.MonthLocator(interval=3))
    ax.xaxis.set_major_formatter(mdates.DateFormatter("%m.%Y"))
    ax.set(
        title="Оплаты за вычетом возвратов по месяцам",
        xlabel="Месяц оформления заказа",
        ylabel="Оплаты за вычетом возвратов, тыс. ₽",
    )
    ax.margins(x=0.02, y=0.10)
    ax.set_ylim(bottom=min(0, ax.get_ylim()[0]))
    ax.grid(axis="y", color="#DCE4E8")
    ax.set_axisbelow(True)
    plt.show()


def plot_sales_channels(sales_channels: pd.DataFrame) -> None:
    """Сравнить каналы по сумме оплат за вычетом возвратов, в тыс. ₽."""
    channels_by_amount = sales_channels.sort_values(
        "net_paid_thousand_rub", ascending=False
    )
    _, ax = plt.subplots(figsize=(8, 4), layout="constrained")
    bars = ax.bar(
        channels_by_amount["sales_channel"],
        channels_by_amount["net_paid_thousand_rub"],
        color="#166A73",
        width=0.58,
    )
    ax.bar_label(bars, fmt="%.0f", padding=4)
    ax.margins(y=0.14)
    ax.set(
        title="Оплаты за вычетом возвратов по каналам",
        xlabel="Канал продаж",
        ylabel="Оплаты за вычетом возвратов, тыс. ₽",
    )
    ax.grid(axis="y", color="#DCE4E8")
    ax.set_axisbelow(True)
    plt.show()


def plot_top_products(products: pd.DataFrame) -> None:
    """Показать десять товаров с наибольшей валовой прибылью, в тыс. ₽."""
    top_products = products.nlargest(10, "gross_profit_rub_thd")
    _, ax = plt.subplots(figsize=(9, 5), layout="constrained")
    ranks = range(len(top_products))
    bars = ax.barh(ranks, top_products["gross_profit_rub_thd"], color="#166A73")
    ax.set_yticks(ranks, labels=top_products["product_name"])
    ax.invert_yaxis()
    ax.bar_label(bars, fmt="%.0f", padding=4)
    ax.margins(x=0.13)
    ax.set(
        title="Топ-10 товаров по валовой прибыли",
        xlabel="Валовая прибыль, тыс. ₽",
    )
    ax.grid(axis="x", color="#DCE4E8")
    ax.set_axisbelow(True)
    plt.show()
