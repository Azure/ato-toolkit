package utils

import "log"

func CheckErrorOrDie(e error) {
	if e != nil {
		log.Fatal(e)
	}
}
