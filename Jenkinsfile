pipeline {
    agent { label 'DEV' }

    stages {
        stage('Hello') {
            steps {
                echo 'Hello World'
                sh 'echo ciao mondo'
            }
        }
        stage('Build'){
            steps{
                sh '''
                    gradle -v
                '''
            }
        }
    }
}
