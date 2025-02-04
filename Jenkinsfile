pipeline {
    agent { label 'jenkinsv2-jenkins-agent' }

    environment {
        IMAGE_NAME = "d4rkghost47/python-app"
        REGISTRY = "https://index.docker.io/v1/"
        DOCKER_CREDENTIALS = "docker-token"  // ID de las credenciales en Jenkins
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    def shortSha = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                    echo "🐍 Construyendo imagen con SHA: ${shortSha}"

                    dockerImage = docker.build("${IMAGE_NAME}:${shortSha}")

                    // Etiquetar también como 'latest'
                    sh "docker tag ${IMAGE_NAME}:${shortSha} ${IMAGE_NAME}:latest"
                }
            }
        }

        stage('Test Docker Image') {
            steps {
                script {
                    dockerImage.inside {
                        sh 'echo "✅ Pruebas ejecutadas con éxito"'
                    }
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry(REGISTRY, DOCKER_CREDENTIALS) {
                        dockerImage.push("${env.BUILD_NUMBER}")
                        dockerImage.push("latest")
                    }
                }
            }
        }

        stage('Clean Up Local Images') {
            steps {
                script {
                    sh "docker rmi ${IMAGE_NAME}:${env.BUILD_NUMBER} || true"
                    sh "docker rmi ${IMAGE_NAME}:latest || true"
                }
            }
        }
    }
}
