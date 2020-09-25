package utils

import (
	"errors"
)

// MergeMaps merges to maps, giving precedence to the second map.
// ie: if the same key is both maps, x and y, then the value of the key in map y
// will prevail. X and Y remain unmodified.
func MergeMaps(x, y map[string]interface{}) map[string]interface{} {

	merged := make(map[string]interface{})

	if x == nil || y == nil {
		CheckErrorOrDie(errors.New("cant merge null maps"))
	}

	for k, v := range x {
		merged[k] = v
	}
	for k, v := range y {
		merged[k] = v
	}

	return merged
}
