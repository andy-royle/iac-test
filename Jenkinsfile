node {
	stage("clonerepository") {
		checkout scm
		
	}
	stage("validate terraform") {
		sh 'terraform init'
		sh 'terraform validate'
		
	}
	stage("validate format") {
		sh 'terraform fmt -check=false'	
	}	
	
}
