pipeline {
    agent any

    environment {
        REPO_URL = 'https://github.com/AyeKyiPyar/p-t-cucumber.git'
        DOCKER_COMPOSE_FILE = 'docker-compose.yml'
        APP_CONTAINER = 'player-team-cucumber-app'
        APP_JAR = 'target/player-team-cucumber-0.0.1-SNAPSHOT.jar'
    }

    stages {

        stage('Checkout') {
            steps {
                echo '📦 Cloning repository...'
                git branch: 'main', url: "${REPO_URL}"
            }
        }

        stage('Build') {
            steps {
                echo '🏗️ Building Maven project...'
                bat 'mvn clean package -DskipTests'
            }
        }

        stage('Start MySQL for Tests') {
		    steps {
		        script {
		            def mysqlRunning = bat(script: 'docker ps -q -f name=mysql_db', returnStdout: true).trim()
		            if (mysqlRunning == '') {
		                echo '🟢 Starting MySQL container...'
		                bat '''
		                    docker run -d --name mysql_db ^
		                    -e MYSQL_ROOT_PASSWORD=root ^
		                    -e MYSQL_DATABASE=testdb ^
		                    -p 3306:3306 ^
		                    mysql:8.0
		                '''
		            } else {
		                echo '✅ MySQL container already running.'
		            }
		        }
		    }
		}


        stage('Run Cucumber Tests') {
            steps {
                echo '🧪 Running Cucumber tests outside container...'
                // Run tests outside the Spring Boot app container
                 bat 'mvn test -Dcucumber.options="--plugin json:target/cucumber.json"'
            }
        }

        stage('Publish Cucumber Results') {
            steps {
                echo '📊 Publishing Cucumber results...'
                // Use HTML publisher instead of 'cucumber' step
                publishHTML(target: [
                    reportDir: 'target/cucumber-reports',
                    reportFiles: 'cucumber.json',
                    reportName: 'Cucumber Test Report',
                    allowMissing: true,
                    alwaysLinkToLastBuild: true,
                    keepAll: true
                ])
            }
        }

        stage('Build & Deploy App') {
            steps {
                echo '🚀 Deploying Spring Boot app with network...'
                bat 'docker build -t player-team-cucumber:v1.1 .'
                bat 'powershell -Command "Start-Sleep -Seconds 20"' // wait for services
            }
        }
        stage('Run Spring App Container')
        	steps{
				echo ' Run Container......'
				bat 'docker run --name player-team-cucumber-container --network akpsnetwork -it -p 8082:8080 player-team-cucumber:v1.1'
				bat 'powershell -Command "Start-Sleep -Seconds 20"' // wait for services
			}
    }

    post {
        always {
            echo '✅ Pipeline finished. Current Docker containers:'
            bat 'docker ps -a'
        }
        success {
            echo "🎉 Pipeline succeeded! App running at http://localhost:7074/"
        }
        failure {
            echo '❌ Pipeline failed. Check logs above.'
        }
    }
}
