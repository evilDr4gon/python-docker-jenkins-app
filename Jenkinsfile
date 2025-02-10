// Pipeline v1.0.3
pipeline {
    agent { label 'jenkinsv2-jenkins-agent' }

    environment {
        IMAGE_NAME = "d4rkghost47/python-app"
        REGISTRY = "https://index.docker.io/v1/"
        SHORT_SHA = ''
        RECIPIENTS = "jose_reynoso@siman.com,reynosojose2005@gmail.com"
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
                script {
                    sh "git config --global --add safe.directory /home/jenkins/agent/workspace/python-app"
                    env.SHORT_SHA = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                container('dind') {
                    script {
                        echo "🐍 Construyendo imagen con SHA: ${env.SHORT_SHA}"
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

        stage('Update Helm Manifests') {
            steps {
                script {
                    sh """
                    echo "📂 Clonando repo de manifiestos..."
                    git clone https://github.com/tu-usuario/gitops-repo.git
                    cd gitops-repo/helm

                    echo "✏️ Actualizando el values.yaml con la nueva imagen..."
                    sed -i 's|tag: latest|tag: ${env.SHORT_SHA}|g' values.yaml

                    echo "📤 Haciendo commit y push..."
                    git config --global user.email "tu-email@example.com"
                    git config --global user.name "Jenkins"
                    git add values.yaml
                    git commit -m "Update image tag to ${env.SHORT_SHA}"
                    git push origin main
                    """
                }
            }
        }
    }
}

