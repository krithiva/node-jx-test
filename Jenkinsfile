pipeline {
    agent {
        label "jenkins-nodejs"
    }
    environment {
      ORG               = 'krithiva'
      APP_NAME          = 'node-http-demo1'
      CHARTMUSEUM_CREDS = credentials('jenkins-x-chartmuseum')
    }
    stages {
      stage('CI Build and push snapshot') {
        when {
          branch 'PR-*'
        }
        environment {
          PREVIEW_VERSION = "0.0.0-SNAPSHOT-$BRANCH_NAME-$BUILD_NUMBER"
          PREVIEW_NAMESPACE = "$APP_NAME-$BRANCH_NAME".toLowerCase()
          HELM_RELEASE = "$PREVIEW_NAMESPACE".toLowerCase()
        }
        steps {
          container('nodejs') {
            sh "npm install"
            sh "CI=true DISPLAY=:99 npm test"

            sh 'export VERSION=$PREVIEW_VERSION && skaffold build -f skaffold.yaml'


            sh "jx step post build --image $DOCKER_REGISTRY/$ORG/$APP_NAME:$PREVIEW_VERSION"
          }

          dir ('./charts/preview') {
           container('nodejs') {
             sh "make preview"
             sh "jx preview --app $APP_NAME --dir ../.."
           }
          }
        }
      }
       stage('Test') {
            steps {
   // sonar test
              container('nodejs') {
               sh "npm install"
               sh "node . &"
               sh "npm test"
                echo 'Testing..'
            }
        }
        }
      stage('Sonar') {
         steps {
         container('nodejs') {
          sh "npm install sonarqube-scanner --save-dev"
          sh "npm run sonar"
        }
      }
      }

      stage('Build Release') {
        when {
          branch 'master'
        }
        steps {
          container('nodejs') {
            // ensure we're not on a detached head
            sh "git checkout master"
            sh "git config --global credential.helper store"

            sh "jx step git credentials"
            // so we can retrieve the version in later steps
            sh "echo \$(jx-release-version) > VERSION"
          }
          dir ('./charts/node-http-demo1') {
            container('nodejs') {
              sh "make tag"
            }
          }
          container('nodejs') {
            sh "npm install"
            sh "CI=true DISPLAY=:99 npm test"

            sh 'export VERSION=`cat VERSION` && skaffold build -f skaffold.yaml'

            sh "jx step post build --image $DOCKER_REGISTRY/$ORG/$APP_NAME:\$(cat VERSION)"
            //sh "docker tag $DOCKER_REGISTRY/$ORG/$APP_NAME:\$(cat VERSION)  krithiva/$APP_NAME:\$(cat VERSION)"
           // sh "cat my_password.txt | docker login --username krithiva  --password-stdin"
           // sh "docker push krithiva/$APP_NAME:\$(cat VERSION)"
          }
        }
      }
     stage('Promote to Environments') {
        when {
          branch 'master'
        }
        steps {
          dir ('./charts/node-http-demo1') {
            container('nodejs') {
              // promote through all 'Auto' promotion Environments
              sh 'jx promote -b --all-auto --timeout 1h --version \$(cat ../../VERSION)'
            }
          }
        }
      }
    }
    post {
        always {
            cleanWs()
        }
    }
  }
