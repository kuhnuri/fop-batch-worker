package com.elovirta.kuhnuri;

import java.nio.file.Path;

public class FileUtils {
    protected static String getExtension(final Path path) {
        final String name = path.getFileName().toString();
        final int i = name.lastIndexOf('.');
        return i != -1 ? name.substring(i + 1) : null;
    }

    protected static Path withExtension(final Path path, final String extension) {
        final String name = path.getFileName().toString();
        final int i = name.lastIndexOf('.');
        final String base = i != -1
                ? name.substring(0, i)
                : name;
        final String ext = extension.startsWith(".") ? extension : ("." + extension);
        return path.getParent().resolve(base + ext);
    }
}
