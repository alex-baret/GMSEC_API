//go:build gmsec_integration

package gotests

import (
	"strings"
	"testing"

	gmsec "gmsec"
)

func TestT002Config(t *testing.T) {
	cfg := gmsec.NewConfig(nil)
	cfg.AddValue("mw-id", "bolt")
	cfg.AddValue("server", "localhost")

	assertTrue(t, cfg.GetValue("mw-id") == "bolt", "mw-id mismatch")
	assertTrue(t, cfg.GetValue("server") == "localhost", "server mismatch")

	xml := cfg.ToXML()
	assertTrue(t, strings.Contains(xml, "mw-id"), "xml should contain mw-id")

	cfg2 := gmsec.NewConfig()
	cfg2.FromXML(xml)
	assertTrue(t, cfg2.GetValue("mw-id") == "bolt", "from_xml value mismatch")

	cfg2.ClearValue("server")
	assertTrue(t, cfg2.GetValue("server") == "", "clear value expected empty")
}
