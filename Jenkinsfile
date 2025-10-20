pipeline {
    agent any

    triggers {
        // Automatically trigger when a merge happens into main
        githubPush()
    }

    environment {
        PROJECT_ID = "swift-castle-475200-j1"
        REGION = "us-central1"
        SERVICE_NAME = "cloud-run-jenkins-demo"
        IMAGE_NAME = "cloud-run-jenkins-image"
        ARTIFACT_REPO = "node-repo"
        GOOGLE_APPLICATION_CREDENTIALS = credentials('gcp-service-account-key')
        GCLOUD_PATH = "\"C:\\Program Files (x86)\\Google\\Cloud SDK\\google-cloud-sdk\\bin\\gcloud.cmd\""
        IMAGE_TAG = "build-${BUILD_NUMBER}" // Auto-tag each image by build number
    }

    stages {

        stage('Checkout Code') {
            steps {
                echo "Cloning repository..."
                git branch: 'main', url: 'https://github.com/seunking05/Cloud-Run-POC.git', credentialsId: 'github-pat'
            }
        }

        stage('Setup gcloud CLI') {
            steps {
                echo "Authenticating GCP service account..."
                bat """
                    ${GCLOUD_PATH} auth activate-service-account --key-file=%GOOGLE_APPLICATION_CREDENTIALS%
                    ${GCLOUD_PATH} config set project %PROJECT_ID%
                    ${GCLOUD_PATH} config set run/region %REGION%
                """
            }
        }

        stage('Configure Docker Authentication') {
            steps {
                echo "Configuring Docker authentication for Artifact Registry..."
                bat """
                    ${GCLOUD_PATH} auth configure-docker %REGION%-docker.pkg.dev --quiet
                """
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker image with tag %IMAGE_TAG%..."
                bat """
                    docker build -t %REGION%-docker.pkg.dev/%PROJECT_ID%/%ARTIFACT_REPO%/%IMAGE_NAME%:%IMAGE_TAG% .
                """
            }
        }

        stage('Push Docker Image') {
            steps {
                echo "Pushing Docker image to Artifact Registry..."
                bat """
                    docker push %REGION%-docker.pkg.dev/%PROJECT_ID%/%ARTIFACT_REPO%/%IMAGE_NAME%:%IMAGE_TAG%
                """
            }
        }

        stage('Deploy to Cloud Run') {
            steps {
                echo "Deploying to Cloud Run..."
                bat """
                    ${GCLOUD_PATH} run deploy %SERVICE_NAME% ^
                        --image %REGION%-docker.pkg.dev/%PROJECT_ID%/%ARTIFACT_REPO%/%IMAGE_NAME%:%IMAGE_TAG% ^
                        --region %REGION% ^
                        --platform managed ^
                        --allow-unauthenticated ^
                        --project %PROJECT_ID%
                """
            }
        }

        stage('Verify Deployment') {
            steps {
                echo "Verifying Cloud Run deployment..."
                bat """
                    echo Service URL:
                    ${GCLOUD_PATH} run services describe %SERVICE_NAME% ^
                        --region %REGION% ^
                        --project %PROJECT_ID% ^
                        --format="value(status.url)"
                """
            }
        }
    }

    post {
        success {
            echo "✅ Deployment completed successfully! Check Cloud Run for service health."
        }
        failure {
            echo "❌ Deployment failed. Check Jenkins logs for details."
        }
    }
}
