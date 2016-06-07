App.tap_informations = App.cable.subscriptions.create 'TapsChannel',
  received: (data) ->
    $(this).trigger('received', data);
