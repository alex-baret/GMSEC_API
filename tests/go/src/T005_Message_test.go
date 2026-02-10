//go:build gmsec_integration

package gotests

import (
	"strings"
	"testing"

	gmsec "gmsec"
)

func TestT005Message(t *testing.T) {
	msg := gmsec.NewMessage(testSubject("MSG.TEST"), gmsec.Message_PUBLISH)
	msg.AddField(gmsec.NewStringField("FIELD-1", "VALUE-1", false))
	msg.AddField(gmsec.NewBooleanField("FIELD-2", true))
	msg.AddField(gmsec.NewI32Field("FIELD-3", 7))

	assertTrue(t, msg.HasField("FIELD-1"), "expected field FIELD-1")
	assertTrue(t, msg.GetStringValue("FIELD-1") == "VALUE-1", "FIELD-1 mismatch")
	assertTrue(t, msg.GetBooleanValue("FIELD-2"), "FIELD-2 mismatch")
	assertTrue(t, msg.GetIntegerValue("FIELD-3") == 7, "FIELD-3 mismatch")
	assertTrue(t, msg.GetFieldCount() >= 3, "expected at least 3 fields")

	xml := msg.ToXML()
	json := msg.ToJSON()
	assertTrue(t, strings.Contains(xml, "FIELD-1"), "xml should include FIELD-1")
	assertTrue(t, strings.Contains(json, "FIELD-1"), "json should include FIELD-1")
}
