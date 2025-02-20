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
            stages {
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

        stage('Docker Compose Up') {
            steps {
                sh 'docker compose up -d'
            }
        }

        stage('Wait for Consul Services to be Healthy') {
            steps {
                script {
                    def maxRetries = 30 // Numero massimo di tentativi (ogni tentativo = 10s)
                    def retryInterval = 10 // Intervallo tra i tentativi (in secondi)
                    def attempt = 0

                    while (attempt < maxRetries) {
                        def response = sh(script: "curl -s http://localhost:8500/v1/health/state/critical", returnStdout: true).trim()
                        
                        if (response == "[]") {
                            echo "✅ All services are healthy!"
                            break
                        } else {
                            echo "⚠️ Some services are still in critical state. Retrying in ${retryInterval} seconds..."
                            attempt++
                            sleep retryInterval
                        }
                    }

                    if (attempt == maxRetries) {
                        error("❌ Services did not recover within the timeout period!")
                    }
                }
            }
        }

        stage('Docker_compose_down') {
            steps {
                sh 'echo "Stop app"'
                sh 'docker compose down'  // Ferma i container
            }
        }
    }
}
