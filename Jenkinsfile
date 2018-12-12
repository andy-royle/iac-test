node {
	stage("clonerepository") {
		checkout scm
		
	}
	stage("validate terraform") {
		sh 'terraform init'
		sh 'terraform validate'
		
	}
}
