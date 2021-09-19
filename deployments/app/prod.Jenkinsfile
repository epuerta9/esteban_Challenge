pipeline {
  agent any
  stages {
    stage('prebuild') {
      }
      steps {
        echo 'prebuilding'
      }
    }

    stage('build') {
      steps {
        sh 'ls -la '
      }
    }

    stage('postbuild') {
      steps {
        echo 'postbuild'
      }
    }

  }
}