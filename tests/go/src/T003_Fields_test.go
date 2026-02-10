//go:build gmsec_integration

package gotests

import (
	"testing"

	gmsec "gmsec"
)

func TestT003Fields(t *testing.T) {
	f1 := gmsec.NewStringField("STR", "value", true)
	assertTrue(t, f1.GetName() == "STR", "name mismatch")
	assertTrue(t, f1.GetStringValue() == "value", "string value mismatch")
	assertTrue(t, f1.IsHeader(), "header flag mismatch")

	f2 := gmsec.NewI32Field("I32", 42)
	assertTrue(t, f2.GetIntegerValue() == 42, "i32 value mismatch")

	f3 := gmsec.NewBooleanField("BOOL", true)
	assertTrue(t, f3.GetBooleanValue(), "bool value mismatch")

	f4 := gmsec.NewF64Field("DBL", 3.14)
	assertTrue(t, f4.GetDoubleValue() > 3.1 && f4.GetDoubleValue() < 3.2, "double value mismatch")
}
