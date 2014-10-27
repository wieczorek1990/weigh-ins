weigh-ins
---------

Type: hobby project

----

Weigh-ins app with realtime chart/table changes, plain text import/export.

Currently single user.

Components:

* firebase,
* highcharts,
* slim,
* coffeescript,
* jquery,
* jquery-datepicker,
* bootstrap,
* bootstrap-datepicker,
* bootstrap-validator,
* bootstrap-filestyle,
* i18n-js,
* handlebars,
* alertify,
* filereader,
* spin.

Firebase schema:

```
root
  users
    username
      weigh-ins
        date: weight
```
