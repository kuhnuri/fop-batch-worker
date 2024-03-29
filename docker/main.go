package main

import (
	"fmt"
	kuhnuri "github.com/kuhnuri/go-worker"
	"io/ioutil"
	"log"
	"net/url"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

type Args struct {
	src *url.URL
	dst *url.URL
	tmp string
	out string
}

func readArgs() *Args {
	input := os.Getenv("input")
	if input == "" {
		log.Fatalf("Input environment variable not set")
	}
	output := os.Getenv("output")
	if output == "" {
		log.Fatalf("Output environment variable not set")
	}
	src, err := url.Parse(input)
	if err != nil {
		log.Fatalf("Failed to parse input argument %s: %v", input, err)
	}
	dst, err := url.Parse(output)
	if err != nil {
		log.Fatalf("Failed to parse output argument %s: %v", output, err)
	}

	tmp, err := ioutil.TempDir("", "tmp")
	if err != nil {
		log.Fatalf("Failed to create temporary directory: %v", err)
	}
	out, err := ioutil.TempDir("", "out")
	if err != nil {
		log.Fatalf("Failed to create temporary directory: %v", err)
	}
	return &Args{src, dst, tmp, out}
}

func getClasspath(base string) string {
	var jars []string
	jars = append(jars, filepath.Join(base, "config"))
	filepath.Walk(base, func(src string, info os.FileInfo, err error) error {
		if filepath.Ext(src) == ".jar" {
			jars = append(jars, src)
		}
		return nil
	})
	return strings.Join(jars, string(os.PathListSeparator))
}

func convert(srcDir string, dstDir string) error {
	base := "/opt/app"
	classpath := getClasspath(base)
	conf := filepath.Join(base, "fop.xconf")

	filepath.Walk(srcDir, func(src string, info os.FileInfo, err error) error {
		if filepath.Ext(src) == ".fo" {
			rel, err := filepath.Rel(srcDir, src)
			if err != nil {
				return fmt.Errorf("ERROR: Failed to relativize source file path: %v\n", err)
			}
			dst := kuhnuri.WithExt(filepath.Join(dstDir, rel), ".pdf")

			fmt.Printf("Convert %s to %s\n", src, dst)
			cmd := exec.Command("/opt/java/openjdk/bin/java",
				"-cp", classpath,
				"org.apache.fop.cli.Main",
				"-c", conf,
				"-fo", src,
				"-pdf", dst)
			cmd.Stdout = os.Stdout
			cmd.Stderr = os.Stdout

			if err := cmd.Run(); err != nil {
				return fmt.Errorf("ERROR: Failed to convert: %v\n", err)
			}
		}
		return nil
	})

	return nil
}

func main() {
	args := readArgs()

	if _, err := kuhnuri.DownloadFile(args.src, args.tmp); err != nil {
		log.Fatalf("Failed to download %s: %v", args.src, err)
	}

	if err := convert(args.tmp, args.out); err != nil {
		log.Fatalf("Failed to convert %s: %v", args.tmp, err)
	}

	if err := kuhnuri.UploadFile(args.out, args.dst); err != nil {
		log.Fatalf("Failed to upload %s: %v", args.dst, err)
	}
}
