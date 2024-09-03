pipeline {
    agent any

    environment {
        APP = 'target-app'
        SCOPE = 'user99'
    }

    stages {
        stage('Build Docker Image') {
            steps {
                // Build the Docker image
                sh '''
                docker build -t ${SCOPE}/${APP}:latest -f Dockerfile .
                '''
            }
        }

        stage('Run Linting') {
            steps {
                // Run flake8 for linting
                sh '''
                docker run --rm ${SCOPE}/${APP}:latest /app/venv/bin/flake8 --ignore=E501,E231 /app/test_app.py /app/test_cyclones.py
                '''

                // Run pylint for additional linting
                sh '''
                docker run --rm ${SCOPE}/${APP}:latest /app/venv/bin/pylint --errors-only --disable=C0301 /app/test_app.py /app/test_cyclones.py
                '''
            }
        }

        stage('Run Unit Tests') {
            steps {
                // Execute unit tests
                sh '''
                docker run --rm ${SCOPE}/${APP}:latest /app/venv/bin/python -m unittest --verbose --failfast /app/test_app.py /app/test_cyclones.py
                '''
            }
        }

        stage('Run Application') {
            steps {
                // Run the application container
                sh '''
                docker run --rm -d -p 8081:8081 --name ${APP} ${SCOPE}/${APP}:latest
                '''
            }
        }

        stage('Clean Up') {
            steps {
                // Clean up Python cache files
                sh '''
                rm -rf ./__pycache__ ./tests/__pycache__
                rm -f .*~ *.pyc
                '''
            }
        }
    }

    post {
        always {
            echo 'Pipeline execution finished.'
        }
        failure {
            // Stop and remove the application container if the pipeline fails
            sh '''
            docker rm -f ${APP} || true
            '''
        }
    }
}

