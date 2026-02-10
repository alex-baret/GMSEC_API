//go:build gmsec_integration

package gotests

import (
	"testing"

	gmsec "gmsec"
)

func TestT007MessageFactory(t *testing.T) {
	cfg := newConfigWithLogging()
	mf := gmsec.NewMessageFactory(cfg)
	mf.SetStandardFields(newStandardFields())

	hb := mf.CreateMessage("MSG.HB")
	assertTrue(t, hb.HasField("MISSION-ID"), "standard field MISSION-ID missing")

	mf.ClearStandardFields()
	hb2 := mf.CreateMessage("MSG.HB")
	assertTrue(t, !hb2.HasField("MISSION-ID"), "standard fields expected cleared")

	xml := hb.ToXML()
	fromData := mf.FromData(xml, gmsec.DataType_XML_DATA)
	assertTrue(t, fromData.GetSubject() != "", "fromData should produce message subject")
}
