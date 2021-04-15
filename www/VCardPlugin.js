var exec = require('cordova/exec');

module.exports.createVCard = function (arg0, success, error) {
  exec(success, error, 'VCardPlugin', 'createVCard', [arg0]);
};
