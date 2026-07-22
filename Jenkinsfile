pipeline {

    agent any

    tools {
        jdk 'jdk'
        nodejs 'node17'
    }

    environment {
        IMAGE_NAME = "milanrajgupta/starbucks:latest"
    }

    stages {

        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    credentialsId: 'github-token',
                    url: 'https://github.com/milanrajgupta/StarBucks_DevOps.git'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    def scannerHome = tool 'sonar-scanner'

                    withSonarQubeEnv('SonarQube') {
                        sh """
                        ${scannerHome}/bin/sonar-scanner \
                        -Dsonar.projectKey=starbucks \
                        -Dsonar.projectName=starbucks
                        """
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: false, credentialsId: 'SonarQube'
                }
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'npm install'
            }
        }

        stage('Trivy File System Scan') {
            steps {
                sh 'trivy fs . > trivyfs.txt'
            }
        }

        stage('Docker Build') {
            steps {
                sh """
                docker build -t ${IMAGE_NAME} .
                """
            }
        }

        stage('Docker Push') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker', toolName: 'docker') {
                        sh """
                        docker push ${IMAGE_NAME}
                        """
                    }
                }
            }
        }

        stage('Trivy Image Scan') {
            steps {
                sh """
                trivy image ${IMAGE_NAME} > trivyimage.txt
                """
            }
        }

        stage('Deploy to EKS Cluster') {
            steps {
                dir('kubernetes') {
                    script {
                        sh '''
                        echo "========================================"
                        echo "Verifying AWS Credentials"
                        echo "========================================"
                        aws sts get-caller-identity

                        echo "========================================"
                        echo "Updating kubeconfig"
                        echo "========================================"
                        aws eks update-kubeconfig \
                          --region ap-south-1 \
                          --name starbucks-prod

                        echo "========================================"
                        echo "Current Kubernetes Context"
                        echo "========================================"
                        kubectl config current-context

                        echo "========================================"
                        echo "Cluster Nodes"
                        echo "========================================"
                        kubectl get nodes

                        echo "========================================"
                        echo "Deploying Kubernetes Manifests"
                        echo "========================================"
                        kubectl apply -f manifest.yml

                        echo "========================================"
                        echo "Waiting for Deployment"
                        echo "========================================"
                        kubectl rollout status deployment/starbucks-deployment --timeout=300s

                        echo "========================================"
                        echo "Deployment Status"
                        echo "========================================"
                        kubectl get deployment
                        kubectl get pods -o wide
                        kubectl get svc
                        '''
                    }
                }
            }
        }
    }

    /*
    ================================
        EMAIL NOTIFICATION
        CURRENTLY DISABLED
    ================================

    post {
        always {
            script {

                def buildStatus = currentBuild.currentResult
                def buildUser = currentBuild.getBuildCauses('hudson.model.Cause\$UserIdCause')[0]?.userId ?: 'GitHub User'

                emailext(
                    subject: "Build ${buildStatus}: ${env.JOB_NAME} #${env.BUILD_NUMBER}",

                    body: """
                    <h2>Starbucks CI/CD Pipeline Report</h2>

                    <p><b>Project:</b> ${env.JOB_NAME}</p>
                    <p><b>Build Number:</b> ${env.BUILD_NUMBER}</p>
                    <p><b>Status:</b> ${buildStatus}</p>
                    <p><b>Triggered By:</b> ${buildUser}</p>

                    <p>
                    <a href="${env.BUILD_URL}">
                    View Build
                    </a>
                    </p>
                    """,

                    to: "your-email@gmail.com",
                    mimeType: "text/html",
                    attachmentsPattern: "trivyfs.txt,trivyimage.txt"
                )
            }
        }
    }
    */

}
