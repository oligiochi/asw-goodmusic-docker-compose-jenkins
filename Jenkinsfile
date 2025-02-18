pipeline {
    agent { node 'AWS-Vagrant' }

    environment {
        // Aggiungi il percorso di Gradle al PATH globale per tutta la pipeline
        PATH = "/usr/local/gradle/bin:$PATH"
    }

    stages {
        stage('Hello') {
            steps {
                echo 'Hello World'
                sh 'echo ciao mondo'
            }
        }
        stage('Check Env') {
            steps {
                sh 'echo "Running on $(hostname)"'
                sh 'whoami'  // Mostra l'utente con cui gira il job
                sh 'echo "PATH: $PATH"'
                sh 'which gradle || echo "Gradle non trovato!"'
                sh 'which docker || echo "Gradle non trovato!"'
            }
        }
        stage('Build_Gradle') {
            steps {
                sh 'gradle -v'
                sh 'echo "start gradle build"'
                sh 'gradle build'
                sh 'echo "finish gradle build"'
            }
        }
        stage('Build_Images'){
            steps{
                sh 'echo "start docker build"'
                sh 'docker build --rm -t connessioni ./connessioni'
                sh 'docker build --rm -t recensioni ./recensioni'
                sh 'docker build --rm -t recensioni-seguite ./recensioni-seguite'
                sh 'docker build --rm -t apigateway ./api-gateway'
                sh 'echo "finish docker build"'
            }
        }
    }
}
