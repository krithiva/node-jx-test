const sonarqubeScanner = require('sonarqube-scanner');
     sonarqubeScanner({
       serverUrl: 'http://35.188.108.66:9000',
       options : {
       'sonar.sources': '.',
       'sonar.inclusions' : 'packages/core/src/**' // Entry point of your code
       }
     }, () => {});
