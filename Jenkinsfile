pipeline {
    agent { label 'jenkinsv2-jenkins-agent' }

    environment {
        IMAGE_NAME = "d4rkghost47/python-app"
    }

    stages {
        stage('Construir Imagen Docker') {
            steps {
                container('dind') {
                    script {
                        // Configurar el directorio como seguro para Git antes de ejecutar comandos
                        sh "git config --global --add safe.directory /home/jenkins/agent/workspace/python-app"

                        // Obtener el short SHA del commit actual
                        def shortSha = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                        echo "🐍 Construyendo imagen con SHA: ${shortSha}"

                        sh """
                        docker build -t ${IMAGE_NAME}:${shortSha} .
                        docker build -t ${IMAGE_NAME}:latest .

                        # Guardar la imagen en un archivo .tar
                        docker save -o ${IMAGE_NAME}.tar ${IMAGE_NAME}:${shortSha} ${IMAGE_NAME}:latest
                        """

                        // Guardar la imagen como artefacto en Jenkins
                        archiveArtifacts artifacts: "${IMAGE_NAME}.tar", fingerprint: true
                    }
                }
            }
        }

        stage('Subir Imagen Docker') {
            steps {
                container('dind') {
                    script {
                        // Descargar la imagen guardada en el stage anterior
                        sh "docker load -i ${IMAGE_NAME}.tar"

                        // Loguearse al registro usando credenciales seguras
                        withCredentials([string(credentialsId: 'docker-token', variable: 'DOCKER_TOKEN')]) {
                            sh "echo '$DOCKER_TOKEN' | docker login -u 'd4rkghost47' --password-stdin"
                        }

                        // Subir la imagen al registro
                        sh """
                        echo "📤 Subiendo imagen Docker..."
                        docker push ${IMAGE_NAME}:latest
                        docker push ${IMAGE_NAME}:${shortSha}
                        """

                        echo "✅ Imagen subida con éxito"
                    }
                }
            }
        }
    }
}

