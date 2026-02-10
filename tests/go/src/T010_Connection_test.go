//go:build gmsec_integration

package gotests

import (
	"testing"
	"time"

	gmsec "gmsec"
)

type t010Callback struct{ received int }

func (cb *t010Callback) OnMessage(conn gmsec.Connection, msg gmsec.Message) { cb.received++ }

func TestT010Connection(t *testing.T) {
	cfg := newConfigWithLogging()
	conn := gmsec.NewConnection(cfg)
	assertTrue(t, gmsec.ConnectionGetAPIVersion() != "", "api version expected")

	assertNoErr(t, conn.Connect(), "connect")
	defer conn.Disconnect()

	mf := conn.GetMessageFactory()
	mf.SetStandardFields(newStandardFields())

	subj := testSubject("MSG.CONN")
	cb := &t010Callback{}
	assertNoErr(t, conn.Subscribe(subj, cb), "subscribe")
	defer conn.Unsubscribe(subj)

	msg := gmsec.NewMessage(subj, gmsec.Message_PUBLISH)
	msg.AddField(gmsec.NewStringField("DATA", "abc", false))
	assertNoErr(t, conn.Publish(msg), "publish")

	conn.Dispatch()
	if cb.received == 0 {
		_ = conn.Receive(500)
	}
	assertTrue(t, conn.GetLibraryVersion() != "", "library version expected")
	assertTrue(t, conn.GetName() != "", "connection name expected")
	_ = time.Second
}
