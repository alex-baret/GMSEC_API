//go:build gmsec_integration

package gotests

import (
	"testing"

	gmsec "gmsec"
)

func TestT006MessageFieldIterator(t *testing.T) {
	msg := gmsec.NewMessage(testSubject("MSG.IT"), gmsec.Message_PUBLISH)
	msg.AddField(gmsec.NewStringField("A", "a", false))
	msg.AddField(gmsec.NewStringField("B", "b", false))
	msg.AddField(gmsec.NewStringField("C", "c", true))

	it := msg.GetFieldIterator(gmsec.MessageFieldIterator_ALL_FIELDS)
	count := 0
	for it.HasNext() {
		_ = it.Next()
		count++
	}
	assertTrue(t, count >= 3, "expected >= 3 fields from iterator")

	it.Reset()
	assertTrue(t, it.HasNext(), "iterator should have elements after reset")
}
