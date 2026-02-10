//go:build gmsec_integration

package gotests

import (
	"path/filepath"
	"testing"

	gmsec "gmsec"
)

func TestT009ConfigFileIterator(t *testing.T) {
	cf := gmsec.NewConfigFile()
	status := cf.Load(filepath.Join("..", "python3", "src", "addons", "good_config_file.xml"))
	assertNoErr(t, status, "config-file load")

	it := cf.GetConfigIterator()
	count := 0
	for it.HasNext() {
		_ = it.NextConfig()
		count++
	}
	assertTrue(t, count > 0, "expected at least one config entry")

	it.Reset()
	assertTrue(t, it.HasNext(), "iterator should have entries after reset")
}
