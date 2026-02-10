//go:build gmsec_integration

package gotests

import (
	"strings"
	"testing"

	gmsec "gmsec"
)

func TestT001Status(t *testing.T) {
	s1 := gmsec.NewStatus()
	assertTrue(t, !s1.HasError(), "default status should not be an error")
	assertTrue(t, s1.GetClass() == int(gmsec.NO_ERROR_CLASS), "unexpected default class")
	assertTrue(t, s1.GetCode() == int(gmsec.NO_ERROR_CODE), "unexpected default code")

	s2 := gmsec.NewStatus(1, 2, "reason", 3)
	assertTrue(t, s2.HasError(), "status(1,2,...) expected error")
	assertTrue(t, s2.GetClass() == 1, "unexpected class")
	assertTrue(t, s2.GetCode() == 2, "unexpected code")
	assertTrue(t, s2.GetCustomCode() == 3, "unexpected custom code")
	assertTrue(t, strings.Contains(s2.Get(), "reason"), "status string should include reason")

	s2.Reset()
	assertTrue(t, !s2.HasError(), "reset status should not be error")
}
