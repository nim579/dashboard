# dashboard
Web sockets based frontend dashboard

## Useage

1. Install dashboard in project
    ``` bash
    $ boewr install ws-dashboard
    ```
    or manualy load from [lib](./lib/).

2. Include in page for dashboard

3. Configurate dashboard and init
``` js
$(function(){
    new Dashboard({
        url: 'ws://localhost:4000/dashboard',   // Dashboard url
        socketData: {},                         // Data for sending for request dashboard data
        updateTime: 5000,                       // Time interval for sending message in socket (for socketData)
        widgets: [                              // Array of widgets
            {name: "text", dataId: "users_count", extra: {label: "Users count"}} // Widgets settings
        ]
    });
});
```

## Widget settings

* `String` **name** — name/type of widget
* `String` **dataId** — data field for widget, getting from socket data
* `Object` **extra** — extra data for this widget
    * **any_data** — any data for current widget or type of widget
    * `String` **label** — standart field, label of widget

## Default widgets
* standart — show text from field specified in *dataId*
* number — show number from field specified in *dataId*, make shortend and pretty number
* table — show table of data sets. Shema in field specified in *dataId*:
    ``` js
    [
        {"label": "set1", "value": 100},
        {"label": "set2", "value": 100500},
        ...
    ]
    ```
* piechart — draw piechard from field specified in *dataId*. Data structure like in **table** widget
* percentage — show percentage object from field specified in *dataId*, like this:
    ``` js
    {
        "dividend": 10,
        "divider": 100
    }
    ```
* meter — draw [knob](http://anthonyterrien.com/knob/) from field specified in *dataId*. Support extra value `max` from widget settings.
* clock — show clock. Field specified in *dataId* supported settings for [jqTime](https://github.com/nim579/jqTime) plugin. For use modes (default *current*) return field *mode*
    ``` js
    {
        "mode": "current",
        "utc": 1,
        "exp": "hh/MM/ss"
    }
    ```
* status — show text and change background by status. Shema in field specified in *dataId*:
    ``` js
    {
        "status": "success", // warning, error
        "text": "It's OK!"
    }
    ```
* list — show list of strings from field specified in *dataId*:
    ``` js
    [
        {"label": "set1"},
        {"label": "set2"},
        ...
    ]

## Make custom widgets
*Comming soon...*


## TODO
* Beautiful data updating
* More clients
