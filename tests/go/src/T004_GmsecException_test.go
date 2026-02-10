//go:build gmsec_integration

package gotests

import (
	"strings"
	"testing"

	gmsec "gmsec"
)

func TestT004GmsecException(t *testing.T) {
	e1 := gmsec.NewGmsecException(1, 2, 3, "boom")
	assertTrue(t, e1.GetClass() == 1, "class mismatch")
	assertTrue(t, e1.GetCode() == 2, "code mismatch")
	assertTrue(t, e1.GetCustomCode() == 3, "custom code mismatch")
	assertTrue(t, strings.Contains(e1.Get(), "boom"), "exception text should contain reason")

	e2 := gmsec.NewGmsecException(e1)
	assertTrue(t, e2.GetCode() == e1.GetCode(), "copy constructor code mismatch")
}
