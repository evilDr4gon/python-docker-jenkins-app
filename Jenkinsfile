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

                // 🔥 Solución: Marcar el directorio como seguro en Git
                sh "git config --global --add safe.directory /home/jenkins/agent/workspace/python-app"
            }
        }

        stage('Build Docker Image') {
            steps {
                container('dind') {  // 🔥 Asegurar que Docker está disponible
                    script {
                        def shortSha = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                        echo "🐍 Construyendo imagen con SHA: ${shortSha}"

                        sh """
                        docker build -t ${IMAGE_NAME}:${shortSha} .
                        docker tag ${IMAGE_NAME}:${shortSha} ${IMAGE_NAME}:latest
                        """
                    }
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                container('dind') {  // 🔥 Asegurar que Docker está disponible
                    script {
                        docker.withRegistry(REGISTRY, DOCKER_CREDENTIALS) {
                            sh "docker push ${IMAGE_NAME}:${env.BUILD_NUMBER}"
                            sh "docker push ${IMAGE_NAME}:latest"
                        }
                    }
                }
            }
        }

        stage('Clean Up Local Images') {
            steps {
                container('dind') {  // 🔥 Asegurar que Docker está disponible
                    script {
                        sh "docker rmi ${IMAGE_NAME}:${env.BUILD_NUMBER} || true"
                        sh "docker rmi ${IMAGE_NAME}:latest || true"
                    }
                }
            }
        }
    }
}

