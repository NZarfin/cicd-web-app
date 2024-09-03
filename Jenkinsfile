pipeline {
    agent any

    environment {
        APP = 'target-app'
        SCOPE = 'user99'
        TAG = "${new Date().format('yyyy-MM-dd')}-${sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()}"
    }

    stages {
        stage('Install Dependencies') {
            steps {
                script {
                    sh 'pip install --quiet --upgrade --requirement requirements.txt'
                }
            }
        }

        stage('Lint') {
            steps {
                script {
                    sh 'flake8 --ignore=E501,E231 *.py'
                    sh 'pylint --errors-only --disable=C0301 --disable=C0326 *.py'
                }
            }
        }

        stage('Unit Tests') {
            steps {
                script {
                    sh 'python -m unittest --verbose --failfast'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${SCOPE}/${APP}:${TAG} ."
                }
            }
        }

        stage('Run Docker Container') {
            steps {
                script {
                    sh "docker run --rm -d -p 5000:5000 --name ${APP} ${SCOPE}/${APP}:${TAG}"
                }
            }
        }

        stage('Clean Up') {
            steps {
                script {
                    sh "docker container stop ${APP} || true"
                    sh "rm -rf ./__pycache__ ./tests/__pycache__"
                    sh "rm -f .*~ *.pyc"
                }
            }
        }
    }

    post {
        always {
            script {
                // Add any cleanup or notifications you need here
                echo 'Pipeline execution finished.'
            }
        }
    }
}

