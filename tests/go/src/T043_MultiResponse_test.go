//go:build gmsec_integration

package gotests

import (
	"testing"
	"time"

	gmsec "gmsec"
)

type t043Responder struct{}

func (cb *t043Responder) OnMessage(conn gmsec.Connection, msg gmsec.Message) {
	reply := conn.GetMessageFactory().CreateMessage("RESP.DIR")
	reply.SetSubject(testSubject("RESP.DIR"))
	reply.AddField(gmsec.NewU16Field("REQUEST-ID", 0))

	statuses := []string{
		gmsec.Message_ResponseStatus_ACKNOWLEDGEMENT,
		gmsec.Message_ResponseStatus_WORKING_KEEP_ALIVE,
		gmsec.Message_ResponseStatus_WORKING_KEEP_ALIVE,
		gmsec.Message_ResponseStatus_WORKING_KEEP_ALIVE,
		gmsec.Message_ResponseStatus_SUCCESSFUL_COMPLETION,
	}

	for _, status := range statuses {
		reply.SetFieldValue("RESPONSE-STATUS", status)
		conn.Reply(msg, reply)
	}
}

type t043ReplyCB struct{ replies int }

func (cb *t043ReplyCB) OnReply(conn gmsec.Connection, req gmsec.Message, reply gmsec.Message) {
	cb.replies++
}
func (cb *t043ReplyCB) OnEvent(conn gmsec.Connection, status gmsec.Status, event gmsec.ConnectionEvent) {
}

func TestT043MultiResponse(t *testing.T) {
	cfg := newConfigWithLogging()
	cfg.AddValue("mw-multi-resp", "true")

	conn := gmsec.NewConnection(cfg)
	assertNoErr(t, conn.Connect(), "connect")
	defer conn.Disconnect()

	conn.StartAutoDispatch()
	defer conn.StopAutoDispatch()

	responder := &t043Responder{}
	replyCB := &t043ReplyCB{}

	reqSubj := testSubject("REQ.DIR")
	respSubj := testSubject("RESP.DIR")
	assertNoErr(t, conn.Subscribe(respSubj+".+"), "subscribe response")
	assertNoErr(t, conn.Subscribe(reqSubj, responder), "subscribe request")

	request := conn.GetMessageFactory().CreateMessage("REQ.DIR")
	request.SetSubject(reqSubj)
	request.AddField(gmsec.NewStringField("DIRECTIVE-STRING", "Do something!", false))
	request.AddField(gmsec.NewStringField("DESTINATION-COMPONENT", "RESPONDER", false))
	request.AddField(gmsec.NewU16Field("REQUEST-ID", 0))

	conn.Request(request, 5000, replyCB, gmsec.REQUEST_REPUBLISH_NEVER)
	time.Sleep(5 * time.Second)

	assertTrue(t, replyCB.replies == 5, "expected 5 multi-response replies")
}
