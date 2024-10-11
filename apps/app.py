import time
from h2o_wave import app, data, ui, Q, main

from dashboards.realtime_monitoring import execute_query
import logging


logging.basicConfig(level=logging.INFO)


light_theme_colors = "$red $pink $purple $violet $indigo $blue $azure $cyan $teal $mint $green $amber $orange $tangerine".split()  # noqa: E501
dark_theme_colors = "$red $pink $blue $azure $cyan $teal $mint $green $lime $yellow $amber $orange $tangerine".split()

_color_index = -1
colors = dark_theme_colors


def next_color():
    global _color_index
    _color_index += 1
    return colors[_color_index % len(colors)]


_curve_index = -1
curves = "linear smooth step step-after step-before".split()


def next_curve():
    global _curve_index
    _curve_index += 1
    return curves[_curve_index % len(curves)]

async def update_realtime_dataset(q):
    async for data_table in execute_query():
        try:
            latest_block_number = max(
                row["BLOCK_NUMBER"] for row in data_table.to_pylist()
            )
            q.page["block_number_card"].value = str(latest_block_number)
        except Exception as e:
            print(e)

        # try:
        #     import pyarrow as pa
        #     import pyarrow.compute as pc

        #     # Extract block_timestamp column
        #     block_timestamps = data_table.column("BLOCK_TIMESTAMP")

        #     # Convert timestamps to minutes
        #     block_timestamps_minute = pc.strftime(block_timestamps, format="%Y-%m-%d %H:%M")

        #     # Group by minute and count
        #     table = pa.table([block_timestamps_minute], names=["minute"])
        #     grouped_data = table.group_by("minute").aggregate([("minute", "count")])

        #     # Convert grouped data to list and assign it back
        #     existing_data = list(q.page["line_plot"].data)  # Convert Ref to list
        #     new_data = existing_data + [[row["minute"], row["minute_count"]] for row in grouped_data.to_pylist()]  # Append new entries
        #     q.page["line_plot"].data = new_data  # Assign back to Ref
        # except Exception as e:
        #     print(e)

        #     try:
        #         rows = [
        #             ui.table_row(
        #                 name=str(i),
        #             cells=[current_time, str(len(row))]
        #             )
        #             for i, row in enumerate(data_table.to_pylist())
        #         ]
        #         q.page["data_table"].rows = rows
        #     except Exception as e:
        #         print(e)

        await q.page.save()

@app("/demo", mode='broadcast')
async def create_dashboard(q: Q):
    q.page.drop()
    line_plot = ui.plot_card(
        box="1 3 4 4",
        title="Token Transfers Data Size Over Time",
        data=data("time length", -100),
        plot=ui.plot(
            [ui.mark(type="line", x="=time", y="=length", curve="smooth")]
        ),
    )

    block_number_card = ui.small_stat_card(box="1 1 2 2", title="Latest Block Number", value="0")

    # data_table = ui.table(
    #     name='data_table',
    #     columns=[
    #         ui.table_column(name='time', label='Time', sortable=True),
    #         ui.table_column(name='length', label='Data Length', sortable=True),
    #     ],
    #     rows=[],
    #     pagination=ui.table_pagination(total_rows=100, rows_per_page=100)
    # )

    # q.page["line_plot"] = line_plot
    q.page["block_number_card"] = block_number_card
    # q.page["data_table"] = data_table

    await q.page.save()

    try:
        await update_realtime_dataset(q)
    finally:
        await q.close()
