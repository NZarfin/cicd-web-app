pipeline {
    agent any

    environment {
        APP = 'target-app'
        SCOPE = 'user99'
    }

    stages {
        stage('Build Docker Image with Python') {
            steps {
                script {
                    // Build the Docker image and tag it as python-env
                    sh "docker build -t ${SCOPE}/${APP}:python-env -f Dockerfile ."
                }
            }
        }

        stage('Setup Python Environment') {
            steps {
                script {
                    // Run the Docker container with the correct image and set up the virtual environment
                    sh "docker run --rm -v \$PWD:/app -w /app ${SCOPE}/${APP}:python-env python -m venv venv"
                }
            }
        }

        stage('Install Dependencies') {
            steps {
                script {
                    // Activate the virtual environment and install dependencies from requirements.txt
                    sh '''
                        source venv/bin/activate
                        pip install --quiet --upgrade --requirement requirements.txt
                    '''
                }
            }
        }

        stage('Lint') {
            steps {
                script {
                    // Run flake8 and pylint inside the virtual environment
                    sh '''
                        source venv/bin/activate
                        flake8 --ignore=E501,E231 *.py
                        pylint --errors-only --disable=C0301 *.py
                    '''
                }
            }
        }

        stage('Unit Tests') {
            steps {
                script {
                    // Run unit tests inside the virtual environment
                    sh '''
                        source venv/bin/activate
                        python -m unittest --verbose --failfast
                    '''
                }
            }
        }

        stage('Build Docker Image with Application') {
            steps {
                script {
                    // Build the final Docker image with the application, tagged with the current date and short commit hash
                    TAG = "${new Date().format('yyyy-MM-dd')}-${sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()}"
                    sh "docker build -t ${SCOPE}/${APP}:${TAG} -f Dockerfile ."
                }
            }
        }

        stage('Run Docker Container') {
            steps {
                script {
                    // Run the Docker container on port 8081
                    sh "docker run --rm -d -p 8081:8081 --name ${APP} ${SCOPE}/${APP}:${TAG}"
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

