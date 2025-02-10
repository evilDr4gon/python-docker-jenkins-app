pipeline {
    agent { label 'jenkinsv2-jenkins-agent' }

    environment {
        IMAGE_NAME = "d4rkghost47/python-app"
        REGISTRY = "https://index.docker.io/v1/"
        SHORT_SHA = "${GIT_COMMIT[0..7]}"  
        RECIPIENTS = "jose_reynoso@siman.com,reynosojose2005@gmail.com"
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Run Unit Tests') {
            steps {
                container('python') {  
                    script {
                        sh """
                        echo "🔬 Ejecutando pruebas unitarias..."
                        pip install -r requirements.txt
                        pytest tests/ --disable-warnings --maxfail=1
                        """
                    }
                }
            }
            post {
                success {
                    echo "✅ Todas las pruebas unitarias pasaron correctamente."
                }

                failure {
                    mail to: env.RECIPIENTS,
                         subject: "❌ Falla: Pruebas unitarias en ${env.JOB_NAME}",
                         body: "Las pruebas unitarias fallaron en ${env.BUILD_URL}. Revisa los logs."
                    error("❌ Fallaron las pruebas unitarias. Deteniendo pipeline.")
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                container('dind') {
                    script {
                        echo "🐳 Construyendo imagen con SHA: ${env.SHORT_SHA}"
                        sh """
                        docker build -t ${IMAGE_NAME}:${env.SHORT_SHA} .
                        docker tag ${IMAGE_NAME}:${env.SHORT_SHA} ${IMAGE_NAME}:latest
                        """
                    }
                }
            }
        }

        stage('Run Integration Test') {
            steps {
                container('dind') {
                    script {
                        sh """
                        echo "🚀 Ejecutando contenedor para pruebas de integración..."
                        docker run -d --rm --name test-container -p 8080:8080 ${IMAGE_NAME}:${env.SHORT_SHA}
                        sleep 5  # Esperar que el contenedor inicie

                        echo "🔍 Probando endpoint /ping..."
                        docker exec test-container python -c "import urllib.request; exit(0) if urllib.request.urlopen('http://localhost:8080/ping').getcode() == 200 else exit(1)"
                        """
                    }
                }
            }
            post {
                always {
                    sh "echo '🛑 Asegurando que el contenedor de prueba se detenga...' && docker stop test-container || true"
                }
                success {
                    mail to: env.RECIPIENTS,
                         subject: "✅ Éxito: Pruebas de integración en ${env.JOB_NAME}",
                         body: "Las pruebas de integración pasaron correctamente en ${env.BUILD_URL}"
                }
                failure {
                    mail to: env.RECIPIENTS,
                         subject: "❌ Falla: Pruebas de integración en ${env.JOB_NAME}",
                         body: "Las pruebas de integración fallaron en ${env.BUILD_URL}. Revisa los logs."
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                container('dind') {
                    script {
                        withCredentials([string(credentialsId: 'docker-token', variable: 'DOCKER_TOKEN')]) {
                            sh """
                            echo "$DOCKER_TOKEN" | docker login -u "d4rkghost47" --password-stdin
                            docker push ${IMAGE_NAME}:${env.SHORT_SHA}
                            docker push ${IMAGE_NAME}:latest
                            """
                        }
                    }
                }
            }
        }
    }
}

