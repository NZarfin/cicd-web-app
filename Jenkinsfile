pipeline {
    agent any

    environment {
        APP = 'target-app'
        SCOPE = 'user99'
    }

    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    // Build the Docker image with the virtual environment already set up
                    sh "docker build -t ${SCOPE}/${APP}:latest -f Dockerfile ."
                }
            }
        }

        stage('Lint') {
            steps {
                script {
                    // Run linting inside the Docker container using the virtual environment
                    sh "docker run --rm ${SCOPE}/${APP}:latest /app/venv/bin/flake8 --ignore=E501,E231 /app/*.py"
                    sh "docker run --rm ${SCOPE}/${APP}:latest /app/venv/bin/pylint --errors-only --disable=C0301 /app/*.py"
                }
            }
        }

        stage('Unit Tests') {
            steps {
                script {
                    // Run unit tests inside the Docker container using the virtual environment
                    sh "docker run --rm ${SCOPE}/${APP}:latest /app/venv/bin/python -m unittest --verbose --failfast"
                }
            }
        }

        stage('Run Docker Container') {
            steps {
                script {
                    // Run the Docker container on port 8081
                    sh "docker run --rm -d -p 8081:8081 --name ${APP} ${SCOPE}/${APP}:latest"
                }
            }
        }

        stage('Clean Up') {
            steps {
                script {
                    // Clean up Python environment, but do not stop the running Docker container
                    sh '''
                        rm -rf ./__pycache__ ./tests/__pycache__
                        rm -f .*~ *.pyc
                    '''
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline execution finished.'
        }
        failure {
            script {
                // If the pipeline fails, stop and remove the Docker container
                sh '''
                    docker rm -f ${APP} || true
                '''
            }
        }
    }
}

