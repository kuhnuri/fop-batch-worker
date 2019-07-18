package com.elovirta.kuhnuri;

import org.junit.Test;

import java.nio.file.Paths;

import static org.junit.Assert.*;

public class FileUtilsTest {

    @Test
    public void getExtension() {
        assertEquals(null, FileUtils.getExtension(Paths.get("/tmp/foo")));
        assertEquals("bar", FileUtils.getExtension(Paths.get("/tmp/foo.bar")));
        assertEquals("baz", FileUtils.getExtension(Paths.get("/tmp/foo.bar.baz")));
        assertEquals("qux", FileUtils.getExtension(Paths.get("/tmp/foo.bar/baz.qux")));
    }

    @Test
    public void withExtension() {
        assertEquals(Paths.get("/tmp/foo.xxx"), FileUtils.withExtension(Paths.get("/tmp/foo"), "xxx"));
        assertEquals(Paths.get("/tmp/foo.xxx"), FileUtils.withExtension(Paths.get("/tmp/foo"), "xxx"));
        assertEquals(Paths.get("/tmp/foo.xxx"), FileUtils.withExtension(Paths.get("/tmp/foo.bar"), "xxx"));
        assertEquals(Paths.get("/tmp/foo.bar.xxx"), FileUtils.withExtension(Paths.get("/tmp/foo.bar.baz"), "xxx"));
        assertEquals(Paths.get("/tmp/foo.bar.xxx"), FileUtils.withExtension(Paths.get("/tmp/foo.bar.baz"), ".xxx"));
    }
}