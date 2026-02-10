//go:build gmsec_integration

package gotests

import (
	"testing"

	gmsec "gmsec"
)

func TestT016ResourceGenerator(t *testing.T) {
	conn := gmsec.NewConnection(newConfigWithLogging())
	assertNoErr(t, conn.Connect(), "connect")
	defer conn.Disconnect()

	rg := gmsec.NewResourceGenerator(conn, testSubject("RSRC"), 1)
	rg.SetField(gmsec.NewStringField("COMPONENT", "RSRC-GEN", true))

	msg := rg.CreateResourceMessage()
	assertTrue(t, msg.HasField("MESSAGE-SUBTYPE"), "resource message should have MESSAGE-SUBTYPE")

	assertNoErr(t, rg.Start(), "resource generator start")
	assertNoErr(t, rg.Stop(), "resource generator stop")
}
