package com.mastercontrol.rubyscraper;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class RubyDirectory {
    private String directoryName;
    private List<RubyFile> fileNames;
}
