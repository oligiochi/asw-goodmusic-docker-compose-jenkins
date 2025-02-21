pipeline {
    agent any

    stages {
        stage('Vagrant and Docker Operations') {
            agent { label 'AWS-Vagrant' }
            environment {
                PATH = "/usr/local/gradle/bin:$PATH"
            }
            stages {
                stage('Check Env') {
                    steps {
                        sh 'echo "Running on $(hostname)"'
                        sh 'whoami'
                        sh 'echo "PATH: $PATH"'
                        sh 'which gradle || echo "Gradle non trovato!"'
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
                stage('Build_Images') {
                    steps {
                        sh 'echo "start docker build"'
                        sh 'docker build --rm -t connessioni ./connessioni'
                        sh 'docker build --rm -t recensioni ./recensioni'
                        sh 'docker build --rm -t recensioni-seguite ./recensioni-seguite'
                        sh 'docker build --rm -t apigateway ./api-gateway'
                        sh 'echo "finish docker build"'
                    }
                }
                stage('Docker Operations') {
                    agent {
                        docker {
                            image 'docker:dind'
                            args '--privileged'
                        }
                    }
                    stages {
                        stage('Docker test') {
                            steps {
                                sh 'docker --version'
                                sh 'docker-compose --version'
                                sh 'docker images'
                            }
                        }
                        stage('Docker Compose Up') {
                            steps {
                                sh 'docker compose up -d'
                            }
                        }
                        stage('Wait for Consul Services to be Healthy') {
                            environment {
                                CONSUL_URL = "http://localhost:8500/v1/health/state/any"
                            }
                            steps {
                                script {
                                    def maxRetries = 30
                                    def retryInterval = 10
                                    def attempt = 0

                                    while (attempt < maxRetries) {
                                        def response = sh(script: "curl -s ${CONSUL_URL}", returnStdout: true).trim()
                                        if (!response.contains('"Status":"critical"')) {
                                            echo "✅ All services are healthy!"
                                            break
                                        } else {
                                            echo "⚠️ Some services are still critical. Retrying in ${retryInterval} seconds..."
                                            attempt++
                                            sleep retryInterval
                                        }
                                    }

                                    if (attempt == maxRetries) {
                                        error("❌ Services did not reach passing state within the timeout period!")
                                    }
                                }
                            }
                        }
                        stage('Test') {
                            steps {
                                sh 'echo $(curl -s localhost:2200/recensioni/recensioni) | jq .'
                            }
                        }
                        stage('Docker_compose_down') {
                            steps {
                                sh 'echo "Stop app"'
                                sh 'docker compose down'
                            }
                        }
                    }
                }
            }
        }
    }
}
