//go:build gmsec_integration

package gotests

import (
	"testing"

	gmsec "gmsec"
)

func TestT011HeartbeatGenerator(t *testing.T) {
	conn := gmsec.NewConnection(newConfigWithLogging())
	assertNoErr(t, conn.Connect(), "connect")
	defer conn.Disconnect()

	hb := gmsec.NewHeartbeatGenerator(conn, testSubject("HB"), 1)
	hb.SetField(gmsec.NewStringField("COMPONENT", "HB-GEN", true))
	assertNoErr(t, hb.Start(), "heartbeat start")
	hb.ChangePublishRate(2)
	assertNoErr(t, hb.Stop(), "heartbeat stop")
}
