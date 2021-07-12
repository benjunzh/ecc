foreach fileList [glob -nocomplain *.v] {
	exec  iStyle  -p --style=kr $fileList
}

foreach tempList [glob -nocomplain *.orig] {
	file delete $tempList
}
		
	