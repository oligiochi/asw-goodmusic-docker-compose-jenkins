pipeline {
    agent any
    
    stages {
        stage('Hello') {
            steps {
                echo 'Hello World'
                sh 'echo ciao mondo'
            }
        }

        stage('Vagrant'){
            agent { node 'AWS-Vagrant' }
            environment {
                // Aggiungi il percorso di Gradle al PATH globale per tutta la pipeline
                PATH = "/usr/local/gradle/bin:$PATH"
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

        /*
        stage('Start Docker Compose') {
            parallel {
                stage('Docker_compose_up') {
                    steps {
                        sh 'echo "Run app in interactive mode"'
                        sh 'docker compose up -d'  // Avvia in modalità interattiva senza -d
                    }
                }
            }
        }

        stage('Wait for the app to start') {
            steps {
                sh 'echo "Waiting for the app to start..."'
                sleep time: 30, unit: 'SECONDS'  // Attende 30 secondi
                //vedere stato servizio
            }
        }

        stage('Docker_compose_down') {
            steps {
                sh 'echo "Stop app"'
                sh 'docker compose down'  // Ferma i container
            }
        }*/
    }
}
