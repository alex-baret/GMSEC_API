//go:build gmsec_integration

package gotests

import (
	"os"
	"strings"
	"testing"

	gmsec "gmsec"
)

func newConfigWithLogging() gmsec.Config {
	cfg := gmsec.NewConfig(nil)
	cfg.AddValue("LOGLEVEL", "INFO")
	cfg.AddValue("LOGFILE", "STDERR")
	return cfg
}

func newStandardFields() gmsec.FieldList {
	fields := gmsec.NewFieldList()
	fields.PushBack(gmsec.NewStringField("MISSION-ID", "MY-MISSION", true))
	fields.PushBack(gmsec.NewStringField("CONSTELLATION-ID", "MY-CONSTELLATION", true))
	fields.PushBack(gmsec.NewStringField("SAT-ID-PHYSICAL", "MY-SAT-ID", true))
	fields.PushBack(gmsec.NewStringField("SAT-ID-LOGICAL", "MY-SAT-ID", true))
	fields.PushBack(gmsec.NewStringField("FACILITY", "MY-FACILITY", true))
	fields.PushBack(gmsec.NewStringField("DOMAIN1", "MY-DOMAIN-1", true))
	fields.PushBack(gmsec.NewStringField("DOMAIN2", "MY-DOMAIN-2", true))
	fields.PushBack(gmsec.NewStringField("COMPONENT", "MY-COMPONENT", true))
	return fields
}

func testSubject(tag string) string {
	host, _ := os.Hostname()
	host = strings.ToUpper(strings.ReplaceAll(host, ".", "_"))
	base := "NIGHTRUN.GO." + host
	if tag == "" {
		return base
	}
	return base + "." + strings.ToUpper(tag)
}

func assertNoErr(t *testing.T, status gmsec.Status, ctx string) {
	t.Helper()
	if status.HasError() {
		t.Fatalf("%s failed: %s", ctx, status.Get())
	}
}

func assertTrue(t *testing.T, cond bool, msg string) {
	t.Helper()
	if !cond {
		t.Fatal(msg)
	}
}
