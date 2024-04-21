import os
import flask
import typing
import plotly.express as ple

import pandas as pd
import statsmodels.api as smapi


if typing.TYPE_CHECKING:
    from statsmodels.tsa.arima.model import ARIMA


app = flask.Flask('prognosis_api')
models = {}


def get_data() -> pd.DataFrame:
    data = pd.read_csv('data_hakaton1.csv', index_col='Unnamed: 0')
    data['Sale_Date'] = pd.to_datetime(data['Sale_Date'])
    data['Date'] = data['Sale_Date'].dt.date

    daily_data = data.groupby("Date")['Product_Name'].value_counts().reset_index(name='count').set_index('Date')
    daily_data_d = daily_data.groupby('Date').apply(lambda d: dict(zip(d['Product_Name'], d['count'])))
    daily_data_df = pd.DataFrame.from_records(daily_data_d.values, index=daily_data_d.index).fillna(0).sort_values('Date')
    daily_data_df = daily_data_df.set_index(pd.to_datetime(daily_data_df.index))
    daily_data_df = daily_data_df[daily_data_df.index.year < 2024].sort_values('Date')
    daily_data_df = daily_data_df.resample('W').sum()

    return daily_data_df

def get_models() -> dict[str, 'ARIMA']:
    models = {}

    for p in os.listdir('models'):
        models[p.replace('.pickle', '')] = smapi.load('models/' + p)
    return models


Data = get_data()
Models = get_models()


@app.route("/prognose", methods=["GET"])
def prognose():
    product = flask.request.args.get("product")
    n_weeks = flask.request.args.get("n_weeks")

    if not product or not n_weeks:
        return "Pass `products` and `n_weeks` args", 500

    if int(n_weeks) <= 0:
        return "Arg `n_weeks` mus be larger then 0", 500

    if not product in Data.columns:
        return f"Arg `product` must be one of {Data.columns}", 500

    try:
        model = Models[product]
        model_forecast = model.get_forecast(int(n_weeks)).predicted_mean
        prognosis = model_forecast.append(pd.Series({Data.index.max(): Data.loc[Data.index.max()][product]}))

        #plot_data = pd.DataFrame({'History': Data[product], 'Prognosis': prognosis})
        #plot = ple.line(plot_data, x=plot_data.index, y=['History', 'Prognosis'], title=f"Prognosis for '{product}' product for {n_weeks} weeks")
        #plot.update_layout(yaxis_title=f"Num of '{product}' product sales")

        hist = []
        prog = []

        for x, y in Data[product].items():
            hist.append({'x': x, 'y': y})
            prog.append({'x': x, 'y': None})

        first_iter = True
        for x, y in prognosis.items():
            if first_iter:
                prog[len(prog)-1]['y'] = y
                first_iter = False
            else:
                hist.append({'x': x, 'y': None})
                prog.append({'x': x, 'y': y})

        plot_cfg = {
            'type': 'line',
            'data': {
                'datasets': [
                    {'data': hist},
                    {'data': prog}
                ]
            }
        }

        return flask.jsonify(plot_cfg), 200
    except Exception as ex:
        return str(ex), 500


if __name__ == "__main__":
    app.run()