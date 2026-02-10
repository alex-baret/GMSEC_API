//go:build gmsec_integration

package gotests

import (
	"path/filepath"
	"testing"

	gmsec "gmsec"
)

func TestT008ConfigFile(t *testing.T) {
	cf := gmsec.NewConfigFile()
	path := filepath.Join("..", "python3", "src", "addons", "good_config_file.xml")
	status := cf.Load(path)
	assertNoErr(t, status, "config-file load")
	assertTrue(t, cf.IsLoaded(), "config file should be loaded")

	cfg := cf.LookupConfig("config1")
	assertTrue(t, cfg != nil, "config1 should exist")

	msg := cf.LookupMessage("msg1")
	assertTrue(t, msg != nil, "msg1 should exist")
}
