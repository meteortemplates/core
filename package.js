Package.describe({
  name: 'templates:core',
  summary: 'Templates namespacing utils and core abstractions.',
  version: '1.1.0',
  git: 'https://github.com/meteortemplates/core.git'
});

Package.onUse(function(api) {
  api.versionsFrom('METEOR@1.0');

  api.use([
    'blaze',
    'check',
    'coffeescript',
    'underscore'
  ], 'client');

  api.addFiles('templates:core.coffee', 'client');
});

Package.onTest(function(api) {
  api.use('tinytest');
  api.use('templates:core');
  api.addFiles('templates:core-tests.js');
});
